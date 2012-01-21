import pymongo
import time

last_time = None
n = 0

cx = pymongo.Connection('localhost:4002')
config = cx.config
changes = config.changelog.find(tailable=True, await_data=False)

while True:
    try:
        for change in changes:
            last_time = change['time']
            n += 1
            print n
            print change
    except Exception, e:
        print e
        cx = pymongo.Connection('localhost:4002')
        config = cx.config


    if last_time is not None:
        changes = config.changelog.find(
            {'time': { '$gt': last_time}},
            tailable=True,
            await_data=True,
        )
    else:
        changes = config.changelog.find(tailable=True, await_data=True)

    # Don't slam MongoDB too hard
    time.sleep(1)
