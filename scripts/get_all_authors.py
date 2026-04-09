import json
import requests 
import time

count = 0
start = 0
url_base = 'http://api.archives-ouvertes.fr/ref/author?rows=10000'

while True:
    url = url_base + f'&start={start}'
    response = requests.get(url)
    filename = f'authors/author_page_{count}.json'
    with open(filename, 'w') as f:
        json.dump(response.json(), f, indent=4)
    start += 10000
    count += 1 
    
    if "error" in response.json():
        print(response.json())
        break 
    elif "response" in response.json():
        print(f'starting at entry: {start}, page number: {count}')
        time.sleep(30)