# -*- coding: utf-8 -*-
import numpy as np
#import tqdm
from itertools import permutations

def get_unique_routes(X):
    '''Get the unique route from the grid
    Input
        X: 2D-like array
    Output
        unique_routes: unique set of routes for right-down path
    '''
    # Select unique route
    a = X.shape[1] # num col
    b = X.shape[0] # num row
    y = np.array([1]*(a-1) + [-1]*(b-1)) # Define 1 as rightward, -1 as downword
    pp = set(permutations(y, a-1+b-1))
    unique_routes = np.array(list(pp))

    ## Sort the set of unique routes
    ind = np.lexsort([unique_routes[:,i] for i in range(unique_routes.shape[1])][::-1])    
    unique_routes = unique_routes[ind]
    
    return unique_routes

def get_path_from_routes(X, unique_routes):
    '''Get the unique path from the grid
    Input
        X: 2D-like array
        unique_routes: unique set of routes for right-down path
    Output
        unique_paths: list of path (tuple as location)
    '''
    unique_path_list = []
    idx = 0
    for route in unique_routes:
        # Get path from route
        # path is the list of locations followed by route
        cnt = 0
        path = [(0,0)]
        for movement in route:
            if movement == 1:
                current_location = path[cnt]
                next_location = (current_location[0], current_location[1]+1)
                path.append(next_location)
                cnt += 1
            elif movement == -1:
                current_location = path[cnt]
                next_location = (current_location[0]+1, current_location[1])
                path.append(next_location)
                cnt += 1

        unique_path_list.append({'path_id': idx,
                                'path': path
        })

        idx += 1
        
    return unique_path_list


def get_weight_from_path(X, path):
    '''Calculate the sum of weight from grid using selected path
    Input
        X: 2D-like array
        path: list of tuple as location
    Output
        weight: sum of the weight followed by the path
    '''
    # Get sum of weight from path
    weight = 0
    for lo in path:
        weight += X[lo[0]][lo[1]]
    return weight


def get_max_path_idx(X, unique_paths):
    '''Calculate the sum of weight from grid using all unique paths. Then find the max route.
    Input
        X: 2D-like array
        unique_paths: list of path (tuple as location)
    Output
        max_idx: path idx with maximum weight
        max_weight: maximum vlaue of sum of the weight followed by the path
    '''
    # Get path info and select maximum route
    max_idx = 0
    max_weight = 0

    # Using unique path info
    if type(unique_paths) is not list:
        unique_paths = unique_paths[0]

    idx_list = list(range(len(unique_paths)))
    np.random.shuffle(idx_list)
    
    for idx in idx_list:
        path_info = unique_paths[idx]
        path_idx = path_info['path_id']
        path = path_info['path']

        weight = get_weight_from_path(X, path)

        if weight >= max_weight:
            max_weight = weight
            max_idx = path_idx

    return max_idx, max_weight


def bayesian_bootstrap(X, statistic, n_replications, *arg):
    ''' Bayesian Bootstrap for 2D weight matrix samples
    Input
        X: 2D-like array
        statistic: A function of the data to use in simulation (Function mapping array-like to number)
        n_replications: The number of bootstrap replications to perform (positive integer)
    Output
        samples: bootstrapped samples (list)
    '''
    weights = np.random.dirichlet([1] * len(X.flatten()), n_replications)

    nc = X.shape[1] # num col
    nr = X.shape[0] # num row

    samples = []
#    for w in tqdm.tqdm(weights):
    for w in weights:
        weighted_X = np.multiply(X, w.reshape(nr, nc))
        if arg == None:
            s, _ = statistic(weighted_X)
        else:
            s, _ = statistic(weighted_X, arg)
        samples.append(s)
    return samples


def get_path_info_from_matrix(X):
    '''Simulate available route and get the path info
    Input
        X: 2D-like array
    Output
        max_idx: path_id which has the maximum weight
        path_info_list: list of dict including path info(path_id, path and sum of weight)
    '''
    unique_routes = get_unique_routes(X)

    # Get path info and select maximum route
    idx = 0
    max_idx = 0
    max_weight = 0

    path_info_list = []
    for route in unique_routes:
        # Get path from route
        # path is the list of locations followed by route
        cnt = 0
        path = [(0,0)]
        for movement in route:
            if movement == 1:
                current_location = path[cnt]
                next_location = (current_location[0], current_location[1]+1)
                path.append(next_location)
                cnt += 1
            elif movement == -1:
                current_location = path[cnt]
                next_location = (current_location[0]+1, current_location[1])
                path.append(next_location)
                cnt += 1

        weight = get_weight_from_path(X, path)

        if weight >= max_weight:
            max_weight = weight
            max_idx = idx
        
        path_info_list.append({'path_id': idx,
                               'path': path,
                               'sum_of_weight': weight
                               })

        idx += 1
    
    return max_idx, path_info_list
