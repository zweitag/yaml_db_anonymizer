require 'spec_helper'

describe JsonDb::Anonymizer do
  before do
    ENV['class'] = 'JsonDb::Anonymizer::Helper'
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
      File.stub!(:new).with('dump.json', 'w').and_return(StringIO.new)
      @io = StringIO.new
    end

    it "should dump a valid json document with correct data" do
      ActiveRecord::Base.connection.stub!(:columns).and_return([ mock('a',:name => 'a', :type => :string), mock('b', :name => 'b', :type => :string) ])

      JsonDb::Anonymizer::Dump.dump(@io)
      @io.rewind
      expect { @json = JSON.load @io }.not_to raise_error

      @json['mytable']['columns'].count.should == 2
      @json['mytable']['records'].should match_array [[1, 2], [3, 4]] 
    end

    context 'tables' do
      it 'dumps rails schema tables' do
        JsonDb::Anonymizer::Dump.tables.should == %w(mytable schema_info schema_migrations)
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
        JsonDb::Anonymizer::Dump.dump_table_columns(@io, 'mytable')
        @io.rewind
        @io.read.should == ""
      end

      it 'should not export records for truncated tables' do
        JsonDb::Anonymizer::Dump.dump_table_records(@io, 'mytable')
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
        JsonDb::Anonymizer::Dump.dump_table_records(@io, 'mytable')
        @io.rewind
        @io.read.should == '"records": [ [0,2],[0,4] ]'
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
      YamlDb::Dump.should_receive(:dump_table_records).with(io, table)
      YamlDb::Anonymizer::Dump.dump_table_records(io, table)
    end

    it 'falls back to YamlDb::Dump.dump_table_columns if definition is missing' do
      YamlDb::Dump.should_receive(:dump_table_columns).with(io, table)
      YamlDb::Anonymizer::Dump.dump_table_columns(io, table)
    end
  end
end

