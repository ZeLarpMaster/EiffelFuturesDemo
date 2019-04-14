note
	description: "demo application root class"
	date: "$Date$"
	revision: "$Revision$"

class
	APPLICATION

inherit
	ARGUMENTS_32

create
	make

feature {NONE} -- Initialization

	make
		local
			cl: DEFAULT_HTTP_CLIENT
			sess: HTTP_CLIENT_SESSION
		do
			create cl
			sess := cl.new_session ("http://example.com")
			if attached sess.get ("/path-to-test", Void) as l_response then
				if not l_response.error_occurred then
					if attached l_response.body as l_body then
						print (l_body)
					end
				else
					print(l_response.error_message)
					print("Error occured%N")
				end
			end
		end

	make2
			-- Run application.
		local
			l_before, l_after: TIME
			l_duration: TIME_DURATION
		do
			create l_before.make_now_utc

			sync_queries(100)

			create l_after.make_now_utc
			l_duration := l_after.relative_duration(l_before)
			print("Took: " + l_duration.fine_seconds_count.out + "%N")
		end

feature {NONE} -- Implementation

	sync_queries(a_num: INTEGER)
		local
			l_client: NET_HTTP_CLIENT_SESSION
			l_response: HTTP_CLIENT_RESPONSE
			l_ctx: HTTP_CLIENT_REQUEST_CONTEXT
		do
			create l_ctx.make
			create l_client.make("http://www.perdu.com")
			l_client.set_user_agent("Mozilla/5.0")
			across 1 |..| a_num as la_num loop
				l_response := l_client.get("/potato", l_ctx)
				if attached l_response.body as la_body then
					print("Got body: " + la_body.out + "%N")
				end
				if l_response.status /= 200 then
					print("Got non-200 response: " + l_response.status.out + "%N")
				end
			end
		end

end
