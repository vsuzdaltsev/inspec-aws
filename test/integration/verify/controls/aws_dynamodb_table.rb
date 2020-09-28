title 'Test single AWS DynamoDB Table'

aws_dynamodb_table_name = attribute(:aws_dynamodb_table_name, value: '', description: 'The AWS Dynamodb Table name.')
aws_dynamodb_table_arn = attribute(:aws_dynamodb_table_arn, value: '', description: 'The AWS Dynamodb Table arn.')

control 'aws-dynamodb-table-1.0' do

  impact 1.0
  title 'Ensure AWS Dynamodb Table has the correct properties.'

  describe aws_dynamodb_table(table_name: aws_dynamodb_table_name) do
    it { should exist }
    its('table_name')                    { should eq aws_dynamodb_table_name }
    its('table_arn')                     { should eq aws_dynamodb_table_arn }
    its('table_status')                  { should eq 'ACTIVE' }
    its('creation_date')                 { should be > '01/01/2019' }
    its('provisioned_throughput.number_of_decreases_today')     { should cmp 0 }
    its('provisioned_throughput.write_capacity_units')          { should cmp 20 }
    its('provisioned_throughput.read_capacity_units')           { should cmp 20 }
    its('item_count')                    { should cmp 0 }
    its('sse_description.status')        { should eq 'ENABLED' }
    its('sse_description.sse_type')      { should eq 'KMS' }
  end

  aws_dynamodb_table(table_name: aws_dynamodb_table_name).global_secondary_indexes.each do |global_sec_idx|
    describe global_sec_idx do
      its('index_name') { should eq 'TitleIndex' }
      its('index_status') { should eq 'ACTIVE' }
      its ('key_schema.first') { should include(attribute_name: 'Title') }
      its('provisioned_throughput.write_capacity_units') { should cmp 10 }
      its('provisioned_throughput.read_capacity_units') { should cmp 10 }
      its('projection.projection_type') { should eq 'INCLUDE' }
    end
  end

  describe aws_dynamodb_table(table_name: 'NotThere') do
    it { should_not exist }
  end
end
