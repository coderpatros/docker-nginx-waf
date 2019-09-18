#!/usr/bin/env python3
import datetime
import json
import os
import statistics
import threading
import time
import urllib.request

TARGET_TOTAL=250000
CONCURRENCY=100

PASSED = 0
FAILED = 0
TOTAL = 0

state_lock = threading.Lock()

def single_test():
    current_timestamp = time.time()
    url = 'http://nginx-waf:8080?t=' + str(current_timestamp) #DevSkim: ignore DS137138
    try:
        contents = urllib.request.urlopen(url).read()
        return b'Welcome to nginx!' in contents
    except Exception as exc:
        print('FAILED REQUEST:', url, exc)
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
    # this is so the image building factors in as it is included in previous-builds.json times
    if os.path.isfile('start.timestamp'):
        with open('start.timestamp') as f:
            start_timestamp = f.read()
        start = datetime.datetime.fromtimestamp

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

    if os.path.isfile('previous-builds.json'):
        with open('previous-builds.json', 'rt') as f:
            builds_json = f.read()
        builds = json.loads(builds_json)
        build_durations = []
        time_format = '%Y-%m-%dT%H:%M:%S'
        for build in builds:
            start_time = datetime.datetime.strptime(build['startTime'].partition('.')[0], time_format)
            finish_time = datetime.datetime.strptime(build['finishTime'].partition('.')[0], time_format)
            duration = finish_time - start_time
            build_durations.append(duration.total_seconds())
        # Formula for Z score = (Observation — Mean)/Standard Deviation
        print()
        print('Count:', len(build_durations))
        print('Max:', max(build_durations))
        print('Min:', min(build_durations))
        mean = statistics.mean(build_durations)
        print('Mean:', mean)
        standard_deviation = statistics.stdev(build_durations)
        print('Standard deviation:', standard_deviation)
        print('This run:', duration.total_seconds())
        z_score = (duration.total_seconds() - mean) / standard_deviation
        print('Z-score:', z_score)
        if 'Z_SCORE' in os.environ:
            max_z_score = float(os.environ['Z_SCORE'] or 0)
        else:
            max_z_score = 0.0
        print('Maximum z-score:', max_z_score)
        if z_score > max_z_score:
            print('Z-score above maximum')
            exit(1)
        else:
            print('Z-score below maximum')

    exit(FAILED)