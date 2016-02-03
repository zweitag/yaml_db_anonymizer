require 'spec_helper'

describe CsvDb::Anonymizer do
  before do
    ENV['class'] = 'CsvDb::Anonymizer::Helper'
    YamlDb::Anonymizer.define {}
  end

  after do
    ENV.delete 'class'
  end

  context 'export' do
    before do
      # Taken from yaml_db specs
      silence_warnings { ActiveRecord::Base = mock('ActiveRecord::Base').as_null_object }
      ActiveRecord::Base.stub(:connection).and_return(stub('connection').as_null_object)
      ActiveRecord::Base.connection.stub!(:tables).and_return([ 'mytable', 'schema_info', 'schema_migrations' ])
      ActiveRecord::Base.connection.stub!(:columns).with('mytable').and_return([ mock('a',:name => 'a', :type => :string), mock('b', :name => 'b', :type => :string) ])
      ActiveRecord::Base.connection.stub!(:select_one).and_return({"count"=>"2"})
      ActiveRecord::Base.connection.stub!(:select_all).and_return([ { 'a' => 1, 'b' => 2 }, { 'a' => 3, 'b' => 4 } ])
    end

    before(:each) do
      # Taken from yaml_db specs
      File.stub!(:new).with('dump.csv', 'w').and_return(StringIO.new)
      @io = StringIO.new
    end

    it "should dump an valid csv document with correct data" do
      ActiveRecord::Base.connection.stub!(:columns).and_return([ mock('a',:name => 'a', :type => :string), mock('b', :name => 'b', :type => :string) ])

      CsvDb::Anonymizer::Dump.dump(@io)
      @io.rewind
      expect { @csv = CSV.parse(@io.read) }.not_to raise_error
      @csv[0].should match_array ['BEGIN_CSV_TABLE_DECLARATIONmytableEND_CSV_TABLE_DECLARATION']
      @csv[1].count.should == 2
      @csv[2,2].should match_array [%w[1 2], %w[3 4]]
    end

    context 'tables' do
      it 'dumps rails schema tables' do
        CsvDb::Anonymizer::Dump.tables.should == %w(mytable schema_info schema_migrations)
      end
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
        CsvDb::Anonymizer::Dump.dump_table_columns(@io, 'mytable')
        @io.rewind
        @io.read.should == ""
      end

      it 'should not export records for truncated tables' do
        CsvDb::Anonymizer::Dump.dump_table_records(@io, 'mytable')
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
        CsvDb::Anonymizer::Dump.dump_table_records(@io, 'mytable')
        @io.rewind
        @io.read.should == "0,2\n0,4\n"
      end
    end
  end

  context 'fallback' do
    let(:io)    { double('io') }
    let(:table) { double('table') }

    before do
      YamlDb::Anonymizer.definition = nil
    end

    it 'falls back to YamlDb::Dump.dump_table_records if definition is missing' do
      CsvDb::Dump.should_receive(:dump_table_records).with(io, table)
      CsvDb::Anonymizer::Dump.dump_table_records(io, table)
    end

    it 'falls back to YamlDb::Dump.dump_table_columns if definition is missing' do
      CsvDb::Dump.should_receive(:dump_table_columns).with(io, table)
      CsvDb::Anonymizer::Dump.dump_table_columns(io, table)
    end
  end
end

