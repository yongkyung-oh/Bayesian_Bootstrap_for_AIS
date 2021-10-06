import numpy as np
import pickle

from time import perf_counter 
from functions import *

np.random.seed(12345)

grid_set = [(2,2), (2,3), 
            (2,4), (3,3), 
            (2,5), (3,4),
            (3,5), (4,4), 
            (3,6), (4,5), 
            (4,6), (5,5), 
            (4,7), (5,6), 
            (5,7), (6,6), 
            (5,8), (6,7), 
            (6,8), (7,7),
            (6,9), (7,8)]
n_total_set = [100, 1000, 10000, 100000]
result = []

for nc, nr in grid_set:
    for n_total in n_total_set:
        start_time = perf_counter()

        X = np.random.randint(low=0, high=100, size=nc*nr).reshape(nr,nc)
        X = np.round(X/np.sum(X)*n_total).astype(int)
        unique_routes = get_unique_routes_np(X)
        unique_paths = get_path_from_routes(X, unique_routes)

        boot_sample = bayesian_bootstrap(X, get_max_path_idx, 1000, unique_paths)

        boot_sample_out = []
        for idx in range(0,len(unique_routes)):
            boot_sample_out.append([idx, sum(np.asarray(boot_sample)==idx)])
        boot_sample_out = np.vstack(boot_sample_out)

        best_route = unique_paths[np.argmax(boot_sample_out[:,1])]

        computation_time = perf_counter()-start_time
        result.append([(nc,nr), len(unique_routes), n_total, get_weight_from_path(X, best_route['path']), computation_time])
        print('Grid_size:{} | n_routes: {} | N_total:{} | Computation_time:{}'.format(nc*nr, len(unique_routes), n_total, computation_time))

with open('computation_test-n_total', 'wb') as f:
    pickle.dump(result, f)
    
    