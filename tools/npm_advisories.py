import csv
import json
import requests

def fetch_advisories():
    '''Fetches advisories from npmjs.com in JSON format'''
    url = 'https://www.npmjs.com/advisories/'
    headers = {'X-Spiferack': '1'}
    r = requests.get(url, headers=headers)
    r_json = r.json()
    num_packages = r_json['advisoriesData']['objects'][0]['id']
    params = {'page': '0', 'perPage': num_packages}
    r = requests.get(url, headers=headers, params=params)
    r_json = r.json()
    return r_json['advisoriesData']['objects']

def flatten_advisory(advisory):
    '''Flattens nested JSON object'''
    flattened_advisory = dict()
    for k, v in advisory.items():
        if isinstance(v, dict):
            for k2, v2 in v.items():
                flattened_advisory['_'.join([k, k2])] = v2
        elif isinstance(v, list):
            flattened_advisory[k] = ','.join(v)
        else:
            flattened_advisory[k] = v
    return flattened_advisory


def flatten_advisories(advisories):
    '''Flattens nested JSON objects'''
    flattened_advisories = list(map(flatten_advisory, advisories))
    return flattened_advisories

def output_csv(advisories):
    '''Writes advisories to CSV file'''
    with open('advisories.csv', 'w') as csvfile:
        fieldnames = advisories[0].keys()
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(advisories)

def main():
    '''Starts the main process'''
    advisories = fetch_advisories()
    flattened_advisories = flatten_advisories(advisories)
    output_csv(flattened_advisories)

if __name__ == '__main__':
    main()