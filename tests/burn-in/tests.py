#!/usr/bin/env python3
import datetime
import threading
import time
import urllib.request

CONCURRENCY=200
TARGET_DURATION_MINUTES=60*5
PASSED = 0
FAILED = 0

state_lock = threading.Lock()
keep_running = True

def single_test():
    current_timestamp = time.time()
    url = 'http://nginx?t=' + str(current_timestamp) #DevSkim: ignore DS137138
    try:
        contents = urllib.request.urlopen(url).read()
        return b'Welcome to nginx!' in contents
    except:
        return False

def test():
    global PASSED, FAILED

    successful_requests = 0
    failed_requests = 0
    while keep_running:
        if single_test():
            successful_requests += 1
        else:
            failed_requests += 1
    
    state_lock.acquire()
    PASSED += successful_requests
    FAILED += failed_requests
    state_lock.release()

if __name__ == '__main__':
    start = datetime.datetime.utcnow()

    # start all the workers
    workers = []
    while len(workers) < CONCURRENCY:
        this_worker = threading.Thread(target=test)
        this_worker.start()
        workers.append(this_worker)

    run_until = start + datetime.timedelta(minutes=TARGET_DURATION_MINUTES)
    while datetime.datetime.utcnow() < run_until:
        time.sleep(10)
    
    keep_running = False

    # wait for all the workers to complete
    while len(workers):
        this_worker = workers.pop()
        this_worker.join()
    
    finish = datetime.datetime.utcnow()
    duration = finish - start

    # give nginx a chance to finish flushing it's console output
    time.sleep(10)

    total = PASSED + FAILED
    print('Time taken', duration)
    print('Average of', total / duration.total_seconds(), 'requests/second')
    print('PASSED:', PASSED, ' FAILED:', FAILED, ' TOTAL:', total)

    exit(FAILED)