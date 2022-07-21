import fileinput, requests, json, sys

path_to_srv_config = sys.argv[1]

r = requests.get("https://ip-ranges.amazonaws.com/ip-ranges.json")
#print (r.json())
IPs = ""
for block in r.json()["prefixes"]:
    if block['service'] == "CLOUDFRONT":
        IPs += "  allow " + block['ip_prefix']+";"+"\n"
print(IPs)
for line in fileinput.FileInput(path_to_srv_config,inplace=1):
    if "location / {" in line:
        line=line.replace(line,line+IPs)
    print(line, end='')
