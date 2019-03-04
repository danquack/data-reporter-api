require "json"
require "date"
require_relative "report_repository"

# Checks if the items exits in dynamo
# @param [String] table_name the table to get item from
# @param [Hash] body the report hashed body
# @return [Boolean] if the item exists or not
def check_exists(table_name, body)
  response = get_item(table_name, body["project"], body["date"])
  return response[:results].nil? ? false : true
end

# Validate body has project, and set date if nil
# @param [Hash] body the report hashed body
# @return [Hash] body with a valid project name and date
def validate_body(body)
  if body["project"].nil?
    raise IOError, "Missing project name"
  end
  if body["date"].nil?
    now = Time.now
    body["date"] = DateTime.new(now.year, now.month, now.day, 0, 0, 0, now.zone).iso8601
  end
  return body
end

# Check exists and post body to the table
# @param [String] table_name the table to get item from
# @param [Hash] body the report hashed body
# @return [Hash] the response for API Gateway
def post_response(table_name, body)
  if !check_exists(table_name, body)
    res = put_item(table_name, body)
    return { statusCode: 200, body: JSON.generate(res), headers: {
             'Access-Control-Allow-Origin': "*",
           } }
  else
    return { statusCode: 400, body: JSON.generate({ "error": "Record already exists" }), headers: {
             'Access-Control-Allow-Origin': "*",
           } }
  end
end

# Function to be called by lambda, validates body and send to post
# @param [Hash] event an api gateway event
# @return [Hash] the response for API Gateway
def lambda_handler(event:, context:)
  begin
    body = validate_body(JSON.parse(event["body"]))
    return post_response(ENV["table_name"], body)
  rescue IOError => e
    return { statusCode: 400, body: JSON.generate("Missing project name"), headers: {
             'Access-Control-Allow-Origin': "*",
           } }
  rescue Exception => e
    puts e
    return { statusCode: 500, body: JSON.generate({ "error": "An unknown error occured" }), headers: {
             'Access-Control-Allow-Origin': "*",
           } }
  end
end
