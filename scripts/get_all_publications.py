import json 
import requests
import time

#first 25 are 10000 entries then its 5000 it kept timing out
count = 48
start = (25000 + ((48-25) * 5000)) + (count - 48)
url_base = f'https://api.archives-ouvertes.fr/search?rows=10000'

#loop through until it times out which will happen when the start exceeds the actual number of things 
#the api will respond max of 10000 things so just store each of those 10000 things in a different file for simplicity
while True:
    url = url_base + f'&start={start}'
    response = requests.get(url)
    filename = f'data/data_page_{count}.json'
    with open(filename, 'w') as f:
        json.dump(response.json(), f, indent=4)
    start += 10000
    count += 1
   
    
    if "error" in response.json():
        print(response.json())
        print("if its a timeout thats fine")
        break
    elif "response" in response.json():
        print(f'starting at entry: {start}, page number: {count}')
        time.sleep(61)