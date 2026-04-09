import json
import requests
import datetime
import os
from pathlib import Path

base_url = 'http://api.archives-ouvertes.fr/search/?fl=title_s,publicationDateY_i,publicationDateM_i,publicationDateD_i&indent=True&wt=json'
filename = 'api_response_example.json'
data = ''
new_data = []
count = 0
with open(filename, 'r') as f:
    data = json.load(f)
    
data_directory = Path('date_full_search')
# for batch in os.listdir(data_directory):
#     batch_name = os.fsdecode(batch)
#     print(batch_name + '\n')
#     for data_file in os.fsencode((string)batch_name):
#         print(data_file + '\n')

for file in data_directory.rglob("*"):
    #print(file)
    if count > 20:
        break
    count += 1
    if file.is_file():
        print(file)

#print(data['response']['docs'][1])
# for doc in data['response']['docs']:
#     # if count > 2:
#     #     break
#     url = base_url + f'&fq=docid:{doc["docid"]}'
#     print(url)
#     response = requests.get(url)
#     print(response.json())
#     if 'response' in response.json():
#         print('response in response')
#         print(f'doc: {doc}\n')
#         for element in response.json()['response']['docs']:
#             doc.update(element)
#             #print(element)
#         new_data.append(doc)
#         #new_data.append(response.json()['response']['docs'])
#     elif 'error' in response.json():
#         #print('error in respnse')
#         break
#     count += 1

# print(new_data)
# #print(len(new_data))
# with open('update_test.json', 'w') as f:
#     json.dump(new_data, f, indent=4, ensure_ascii=False)
