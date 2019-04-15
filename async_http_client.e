note
	description: "Summary description for {ASYNC_HTTP_CLIENT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ASYNC_HTTP_CLIENT

create
	make

feature {NONE} -- Initialization

	make(a_base_url: READABLE_STRING_8)
		do
			create client.make(a_base_url)
			client.set_timeout(1)
		end

feature -- Access

	get(a_path: READABLE_STRING_8): FUTURE[HTTP_CLIENT_RESPONSE]
		local
			l_thread: WORKER_THREAD
		do
			create Result.make
			create l_thread.make(agent deferred_get(Result))
			l_thread.launch
		end

feature {NONE} -- Implementation

	client: NET_HTTP_CLIENT_SESSION
			-- The client

	deferred_get(a_future: FUTURE[HTTP_CLIENT_RESPONSE])
		do
			a_future.set_value(client.get("", Void))
		end

end
