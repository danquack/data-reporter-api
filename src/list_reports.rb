require "json"
require_relative "report_repository"

# A service function to process the request
# @param [String] table_name the table to get item from
# @param [Hash] last_key the last evaluated key
# @param [String] project the project name
# @param [String] date the date
# @return [Hash] the response for API Gateway
def get_response(table_name, last_key = nil, project = nil, date = nil)
  log = { "table_name" => table_name, "last_key" => last_key, "project" => project, "date" => date }.to_s
  puts log

  begin
    if !project.nil? && !date.nil?
      response = get_item(table_name, project, date)
    else
      response = scan(table_name, last_key)
    end
    return { statusCode: 200, body: JSON.generate(response), headers: {
             'Access-Control-Allow-Origin': "*",
           } }
  rescue Exception => e
    puts e
    return { statusCode: 500, body: JSON.generaste({ error: "an unknown error occured" }), headers: {
             'Access-Control-Allow-Origin': "*",
           } }
  end
end

# Function to be called by lambda, validates params and send to service
# @param [Hash] event an api gateway event
# @return [Hash] the response for API Gateway
def lambda_handler(event:, context:)
  last_key = nil
  table_name = ENV["table_name"]
  project = nil
  date = nil

  if !event["query"].nil?
    query = event["query"]
    last_key = query["last_project"] && query["last_date"] ? {
      project: query["last_project"],
      date: query["last_date"],
    } : nil
    project = query["project"]
    date = query["date"]
    if !query["table_name"].nil?
      table_name = query["table_name"]
    end
  end
  return get_response(table_name, last_key, project, date)
end
