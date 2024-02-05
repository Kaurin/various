#!/usr/bin/env python

import os
import hashlib
import argparse

def calculate_checksum(file_path):
    hasher = hashlib.md5()
    with open(file_path, 'rb') as file:
        while chunk := file.read(8192):
            hasher.update(chunk)
    return hasher.hexdigest()

def find_identical_files(directory):
    file_checksums = {}

    for foldername, subfolders, filenames in os.walk(directory):
        for filename in filenames:
            file_path = os.path.join(foldername, filename)
            checksum = calculate_checksum(file_path)

            if checksum in file_checksums:
                file_checksums[checksum].append(file_path)
            else:
                file_checksums[checksum] = [file_path]

    for checksum, files in file_checksums.items():
        if len(files) > 1:
            print(f"Checksum: {checksum}")
            for file_path in files:
                print(f"\t{file_path}")

def main():
    parser = argparse.ArgumentParser(description='Find checksum-identical files in a directory tree.')
    parser.add_argument('directory', help='The directory to search for identical files.')

    args = parser.parse_args()
    directory_to_search = args.directory

    find_identical_files(directory_to_search)

if __name__ == "__main__":
    main()

