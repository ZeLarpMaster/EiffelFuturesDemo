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
			-- Run application.
		do
			create event_loop.make
			across 1 |..| 1 as la_nb loop
				print("Test #" + la_nb.item.out + "%N")
				timeit("SYNC", agent sync_queries(100))
				timeit("ASYNC", agent async_queries(100))
			end
		end

feature {NONE} -- Implementation

	event_loop: EVENT_LOOP

	url: STRING_8 = "http://www.google.ca"

	timeit(a_name: READABLE_STRING_GENERAL; a_proc: PROCEDURE[TUPLE])
		local
			l_before, l_after: TIME
			l_duration: TIME_DURATION
		do
			create l_before.make_now_utc

			a_proc.call

			create l_after.make_now_utc
			l_duration := l_after.relative_duration(l_before)
			print("[" + a_name + "] Took: " + l_duration.fine_seconds_count.out + "%N")
		end

	sync_queries(a_num: INTEGER)
		local
			l_client: NET_HTTP_CLIENT_SESSION
			l_response: HTTP_CLIENT_RESPONSE
		do
			create l_client.make(url)
			l_client.set_timeout(1)
			across 1 |..| a_num as la_num loop
				l_response := l_client.get("/", Void)
				if l_response.status /= 200 then
					print("X")
				else
					print("O")
				end
			end
			print("%N")
		end

	async_queries(a_num: INTEGER)
		local
			l_tasks: LIST[TASK]
		do
			create {LINKED_LIST[TASK]} l_tasks.make

			across 1 |..| a_num as la_num loop
				l_tasks.extend(event_loop.create_task(agent async_query))
			end
			print("All tasks have been created%N")

			event_loop.run_until_complete(event_loop.gather(l_tasks))
			print("%N")
		end

	async_query
		local
			l_client: ASYNC_HTTP_CLIENT
			l_future: FUTURE[HTTP_CLIENT_RESPONSE]
		do
			create l_client.make(url)
			l_future := l_client.get("/")
			event_loop.await(l_future)

			if attached l_future.value as la_response then
				if la_response.status /= 200 then
					print("X")
				else
					print("O")
				end
			end
		end

end
