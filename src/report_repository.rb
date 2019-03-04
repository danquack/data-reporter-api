require "aws-sdk-dynamodb"
$client = Aws::DynamoDB::Client.new()

# A function to scan dynamo and get the individual response
# @param [String] table_name the table to scan
# @param [Hash] last_key the exclusive_start_key
# @return [Hash] the response containing scanned items and last key
def scan(table_name, last_key = nil)
  params = {
    table_name: table_name,
    limit: 20,
  }
  if !last_key.nil?
    params.merge!(exclusive_start_key: last_key)
  end

  response = $client.scan(params)
  puts "SCAN Response" + response.to_s
  return {
           results: response.items,
           last_key: response.last_evaluated_key,
         }
end

# A function to get an individual item from dynamo
# @param [String] table_name the table to get item
# @param [String] project the project to search for
# @param [String] date the date to search for
# @return [Hash] the response containing the results
def get_item(table_name, project, date)
  response = $client.get_item({
    key: {
      "project" => project,
      "date" => date,
    },
    table_name: table_name,
  })
  return {
           results: response.item,
         }
end

# A function to PUT into dynamo
# @param [String] table_name the table to put item
# @return [Hash] the item put into the table
# @raise [Exception] any dynamo put exception
def put_item(table_name, item)
  params = {
    table_name: table_name,
    item: item,
    return_values: "NONE",
  }
  $client.put_item(params)
  return item
end
