require 'spec_helper'

describe YamlDb::Anonymizer do
  context 'definition' do
    before do
      YamlDb::Anonymizer.define do
        table :mytable do
          remove :a
          replace :b, with: 0
          replace :c, with: lambda { |val| "Anonymized #{val}" }
        end
      end
    end

    it "should anonymize" do
      YamlDb::Anonymizer.anonymize(:mytable, :a, "foo").should == nil
    end

    it "should anonymize with simple values" do
      YamlDb::Anonymizer.anonymize(:mytable, :b, "foo").should == 0
    end

    it "should anonymize with blocks" do
      YamlDb::Anonymizer.anonymize(:mytable, :c, "bar").should == "Anonymized bar"
    end
  end

  context 'export' do
    before do
      silence_warnings { ActiveRecord::Base = mock('ActiveRecord::Base').as_null_object }
      ActiveRecord::Base.stub(:connection).and_return(stub('connection').as_null_object)
      ActiveRecord::Base.connection.stub!(:tables).and_return([ 'mytable', 'schema_info', 'schema_migrations' ])
      ActiveRecord::Base.connection.stub!(:columns).with('mytable').and_return([ mock('a',:name => 'a', :type => :string), mock('b', :name => 'b', :type => :string) ])
      ActiveRecord::Base.connection.stub!(:select_one).and_return({"count"=>"2"})
      ActiveRecord::Base.connection.stub!(:select_all).and_return([ { 'a' => 1, 'b' => 2 }, { 'a' => 3, 'b' => 4 } ])
      YamlDb::Utils.stub!(:quote_table).with('mytable').and_return('mytable')
    end

    before(:each) do   
      File.stub!(:new).with('dump.yml', 'w').and_return(StringIO.new)
      @io = StringIO.new
    end

    context 'truncated' do
      before do
        YamlDb::Anonymizer.define do
          table :mytable do
            truncate
          end
        end
      end

      it 'should not export headers for truncated tables' do
        YamlDb::Anonymizer::Dump.dump_table_columns(@io, 'mytable')
        @io.rewind
        @io.read.should == ""
      end

      it 'should not export records for truncated tables' do
        YamlDb::Anonymizer::Dump.dump_table_records(@io, 'mytable')
        @io.rewind
        @io.read.should == ""
      end
    end

    context 'anonymized' do
      before do
        YamlDb::Anonymizer.define do
          table :mytable do
            replace 'a', with: 0
          end
        end
      end

      it 'should anonymize the dump with the given schema' do
        YamlDb::Anonymizer::Dump.dump_table_records(@io, 'mytable')
        @io.rewind
        @io.read.should == <<EOYAML
  records: 
  - - 0
    - 2
  - - 0
    - 4
EOYAML
      end
    end
  end
end

