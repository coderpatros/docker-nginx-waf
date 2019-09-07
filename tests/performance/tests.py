#!/usr/bin/env python3
import datetime
import threading
import time
import urllib.request

TARGET_TOTAL=100000
CONCURRENCY=200

PASSED = 0
FAILED = 0
TOTAL = 0

state_lock = threading.Lock()

def single_test():
    current_timestamp = time.time()
    url = 'http://nginx?t=' + str(current_timestamp) #DevSkim: ignore DS137138
    try:
        contents = urllib.request.urlopen(url).read()
        return b'Welcome to nginx!' in contents
    except:
        return False

def test_batch():
    global PASSED, FAILED, TOTAL

    batch_size = int(TARGET_TOTAL / CONCURRENCY)
    batch_progression = 0
    successful_requests = 0
    while batch_progression < batch_size:
        batch_progression += 1
        if single_test():
            successful_requests += 1
    
    state_lock.acquire()
    PASSED += successful_requests
    FAILED += batch_size - successful_requests
    TOTAL += batch_size
    state_lock.release()

if __name__ == '__main__':
    start = datetime.datetime.utcnow()

    # start all the workers
    workers = []
    while len(workers) < CONCURRENCY:
        this_worker = threading.Thread(target=test_batch)
        this_worker.start()
        workers.append(this_worker)

    # wait for all the workers to complete
    while len(workers):
        this_worker = workers.pop()
        this_worker.join()
    
    finish = datetime.datetime.utcnow()
    duration = finish - start

    # give nginx a chance to finish flushing it's console output
    time.sleep(10)

    print('Time taken', duration)
    print('Average of', TOTAL / duration.total_seconds(), 'requests/second')
    print('PASSED:', PASSED, ' FAILED:', FAILED, ' TOTAL:', TOTAL)

    exit(FAILED)