import numpy as np
#import pandas as pd
#import matplotlib.pyplot as plt
import pickle

from time import perf_counter 
from itertools import permutations
from functions import *

np.random.seed(12345)

grid_set = [(2,2), (2,3), (2,4), (3,3), 
            (2,5), (3,4),
            (3,5), (4,4), 
            (3,6), (4,5), 
            (4,6), (5,5), 
            (4,7), (5,6), 
            (5,7), (6,6), 
            (5,8), (6,7), 
            (6,8), (7,7),
            (6,9), (7,8)]
n_rep_set = [100, 1000, 10000, 100000]
result = []

for nc, nr in grid_set:
    start_time = perf_counter()

    X = np.random.randint(low=0, high=100, size=nc*nr).reshape(nr,nc)
    unique_routes = get_unique_routes(X)
    unique_paths = get_path_from_routes(X, unique_routes)

    preprocess_time = perf_counter()-start_time
    print("Preprocess time: {}".format(preprocess_time))

    for n_rep in n_rep_set:
        start_time = perf_counter()

        boot_sample = bayesian_bootstrap(X, get_max_path_idx, n_rep, unique_paths)

        boot_sample_out = []
        for idx in range(0,len(unique_routes)):
            boot_sample_out.append([idx, sum(np.asarray(boot_sample)==idx)])
        boot_sample_out = np.vstack(boot_sample_out)

        best_route = unique_paths[np.argmax(boot_sample_out[:,1])]

        computation_time = perf_counter()-start_time
        result.append([(nc,nr), len(unique_routes), n_rep, get_weight_from_path(X, best_route['path']), preprocess_time+computation_time])
        print('Grid_size:{} | n_routes: {} | N_rep:{} | Computation_time:{}'.format(nc*nr, len(unique_routes), n_rep, preprocess_time+computation_time))


with open('out/computation_test', 'wb') as f:
    pickle.dump(result, f)
    
    