import json
import requests
import os
from pathlib import Path 

base_url = 'http://api.archives-ouvertes.fr/search/?indent=True&wt=json&fl=publicationDateY_i,publicationDateM_i,publicationDateD_i'
data_directory = Path('date_full_search')

for filename in data_directory.rglob("*"):
    if filename.is_file():
        old_data = []
        new_data = []
        print(filename)
        with open(filename, 'r') as file:
            old_data = json.load(file)['response']['docs']
        for doc in old_data:
            url = f'{base_url}&fq=docid{doc["docid"]}'
            response = requests.get(url)
            new_doc = doc
            if 'response' in response.json():
                for element in response.json()['response']['docs']:
                    new_doc.append(element)
            elif 'error' in response.json():                   
                print('error in response')
            new_data.append(new_doc)
        with open(f'/mnt/database_data/{filename}', 'w') as f:
            json.dump(new_data, f, indent=4, ensure_ascii=False)