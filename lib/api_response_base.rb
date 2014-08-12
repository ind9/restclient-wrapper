class ApiResponseBase
	attr_reader :status_code, :status_message
	attr_accessor :data, :errors

	def initialize(status_code, status_message, data, errors = nil)
		@status_code = status_code
		@status_message = status_message
		@data = data
		@errors = errors
	end
end
