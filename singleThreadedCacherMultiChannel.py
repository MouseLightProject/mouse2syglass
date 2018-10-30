#! python2
import sys
import time
from os import path, listdir, makedirs
import numpy as np
from skimage import io
import pyglass

default_max_intensity = 15000.0
default_num_worker_threads = 12
default_max_queue_size = 12


def worker(queue, max_intensity, input_root_path, output_root_path):
    while len(queue) > 0:
        block = queue.pop(0)
        input_folder = path.join(input_root_path, block)
        output_folder = path.join(output_root_path, block)
        try:
            makedirs(output_folder)
        except OSError:
            if not path.isdir(output_folder):
                raise
        valid_folders = [str(n) for n in range(1, 9)]
        children = [x for x in listdir(input_folder) if path.isdir(path.join(input_folder, x)) and x in valid_folders][0:10]
        [queue.append(path.join(block, x)) for x in children]
        start_time = time.time()
        convert(block, input_root_path, output_root_path, max_intensity)
        print '%s, %.1f sec/blocks\n' % (block, time.time() - start_time)


def calc_statistics(x):
    m = np.mean(x)
    c = x - m
    c.shape = (-1)
    return m, np.dot(c, c) / (c.size - 1)


def convert(max_intensity, input_root_path, output_root_path, name_of_log_file):
    output_path = path.join(output_root_path, 'default.tif')
    if path.exists(output_path):
        return

    tiff0 = np.float32(io.imread(path.join(input_root_path, 'default.0.tif')))
    tiff1 = np.float32(io.imread(path.join(input_root_path, 'default.1.tif')))

    (m0, std0) = calc_statistics(tiff0)
    (m1, std1) = calc_statistics(tiff1)

    std = (std0 + std1) / 2
    diff = tiff0 * std / std0 - tiff1 * std / std1 - (m0 / std0 - m1 / std1) * std
    diff *= (128.0 / max_intensity)
    diff8b = np.uint8(np.clip(diff, -128.0, 127.0) + 128.0)

    pyglass.Raster(diff8b).Export(output_path)

    if name_of_log_file != "default":
        with open(name_of_log_file, 'w') as w:
            w.write('1000000')

    #pyglass.CombineRasters(pyglass.Raster(tiff0), pyglass.Raster(tiff1)).Export(output_path)


def process_octree(input_root_path,
                   output_root_path,
                   name_of_log_file = "default",
                   max_intensity=default_max_intensity,
                   max_queue_size=default_max_queue_size,
                   num_worker_threads=default_num_worker_threads):

    convert(max_intensity, input_root_path, output_root_path, name_of_log_file)

if __name__ == '__main__':
    if len(sys.argv) == 3:
        sys.argv.append("default")
    process_octree(sys.argv[1], sys.argv[2], sys.argv[3])
