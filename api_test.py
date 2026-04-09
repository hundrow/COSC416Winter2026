import json
import requests
import datetime

start = 0
#url = f'https://api.archives-ouvertes.fr/search/?fl=label_s,abstract_s,docid,collection_t,uri_s,collCode_s,keyword_s&rows=10000&start=500000&fq=submittedDateY-i:[2025 TO 2026]'
#author_url = 'http://api.archives-ouvertes.fr/ref/authors?rows=10000'
url = 'https://api.archives-ouvertes.fr/search?rows=5&indent=true&wt=json&fl=label_s,abstract_s,docid,collection_t,uri_s,collCode_s,keyword_s,authFullName_s,title_s,domainAll_s,domainAllCode_s,en_domainAllCodeLabel_fs,fr_domainAllCodeLabel_fs,publicationDateY_i,publicationDateM_i,publicationDateD_i'
response = requests.get(url)
print(datetime.datetime.now())
#response_json = response.get_json()
print(response.json(encoding='utf-16'))
#with open('test.json', 'w') as f:
#    json.dump(response.json(), f, indent=4, ensure_ascii=False)
#print(f'{response.status_code}')
#timeout still responds with 200
with open('/mnt/database_data/api_response.json', 'w') as f:
    #f.write(response.text)
    json.dump(response.json(), f, indent=4, ensure_ascii=False)

if "response" in response.json():
    print('response in response')
    docs = response.json()['response']['docs']
    print(f'length of response {len(docs)}')
elif "error" in response.json():
    print('error in response')
    
# start = 40000000
# url = f'https://api.archives-ouvertes.fr/search/?&start={start}'
# response = requests.get(url)
# if "response" in response.json():
#     print('response in response')
# elif "error" in response.json():
#     print('error in response')