require 'spec_helper'

describe MessagePackDb::Anonymizer do
  let(:packer) { MessagePackDb::factory.packer }

  before do
    ENV['class'] = 'MessagePackDb::Anonymizer::Helper'
    YamlDb::Anonymizer.define {}
  end

  after do
    ENV.delete 'class'
  end

  context 'export' do
    let(:connection) { double('connection') }

    before do
      silence_warnings { ActiveRecord::Base = mock('ActiveRecord::Base').as_null_object }
      ActiveRecord::Base.stub!(:connection).and_return(connection)
      connection.stub!(:tables).and_return([ 'mytable', 'schema_info', 'schema_migrations' ])
      connection.stub!(:columns).with('mytable').and_return([ mock('a',:name => 'a', :type => :string, sql_type: 'text'), mock('b', :name => 'b', :type => :string, sql_type: 'text') ])
      connection.stub!(:select_one).and_return({"count"=>"2"})
      connection.stub!(:select_all).and_return([ { 'a' => 1, 'b' => 2 }, { 'a' => 3, 'b' => 4 } ])
      connection.stub!(:quote_table_name) {|table| table }
    end

    before(:each) do
      @io = StringIO.new
    end

    it "should dump a valid messagepack document with correct data" do
      connection.stub!(:columns).and_return([ double('a', name: 'a', type: :string, sql_type: 'text'), double('b', name: 'b', type: :string, sql_type: 'text') ])

      MessagePackDb::Anonymizer::Dump.dump(@io)
      @io.rewind
      tables = []
      records = {}
      unpacker = MessagePackDb.factory.unpacker(@io)
      expect do
        is_header = true
        unpacker.each do |item|
          if is_header
            tables << item
          else
            (records[tables.last.name] ||= []).push(*item)
          end

          is_header = !is_header
        end
      end.not_to raise_error
      expect { unpacker.read }.to raise_error(EOFError)

      expect(tables.count).to eq 3
      table = tables.first
      expect(table.name).to eq('mytable')
      expect(table.columns).to match_array ['a', 'b']
      expect(records[table.name]).to match_array [[1, 2], [3, 4]]
    end

    context 'tables' do
      it 'dumps rails schema tables' do
        MessagePackDb::Anonymizer::Dump.tables.should == %w(mytable schema_info schema_migrations)
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

      it 'should not export truncated tables' do
        MessagePackDb::Anonymizer::Dump.dump_table(packer, 'mytable')
        packer.write_to(@io)
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
        MessagePackDb::Anonymizer::Dump.dump_table_records(packer, 'mytable')
        packer.write_to(@io)
        @io.rewind
        #@io.read.should == '"records": [ [0,2],[0,4] ]' # TODO
      end
    end
  end

  context 'fallback' do
    let(:io)    { double('io') }
    let(:table) { 'mytable' }

    before do
      YamlDb::Anonymizer.definition = nil
    end

    it 'falls back to MessagePackDb::Dump.dump_table_records if definition is missing' do
      MessagePackDb::Dump.should_receive(:dump_table_records).with(packer, table)
      MessagePackDb::Anonymizer::Dump.dump_table_records(packer, table)
    end

    it 'falls back to MessagePackDb::Dump.dump_table_header if definition is missing' do
      MessagePackDb::Dump.should_receive(:dump_table_header).with(packer, table)
      MessagePackDb::Anonymizer::Dump.dump_table_header(packer, table)
    end
  end
end

