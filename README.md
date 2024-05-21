# richmentdb
vulnrichment database project.

THIS IS EXPERIMENTAL PROJECT.
- Vulnrichment itself seems to be updated for a while, so I think we'll just have to wait and see until it stabilizes.
- Modify the database schema as appropriate.
  - But, I want to use it now!

# What can this do?

Import Vulnrichment vulnerability data into a mysql database and make it searchable using SQL statements.
- This is because it is difficult to use the provided JSON as is.

# Setup

## Necessary environment

- docker

## Install

- pull to docker image
  - `$ docker pull hogehuga/richmentdb`
- run docker image
  - `$ docker container run --name richmentdb -e MYSQL_ROOT_PASSWORD=mysql -d hogehuga/richmentdb`
    - optional: container name
      - `--name richmentdb` is container name. Change it as you like.
    - optional: Let's specify the volume of the container
      - `$ docker volume create richmentDB`
      - `$ docker container run --name richmentdb -v richmentDB:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=mysql -d hogehuga/richmentdb`
- createdb and import data from JSON to MySQL
  - `$ docker exec -it richmentdb /bin/bash`
  - `$ cd /opt/richmentdb/init-scripts`
  - `$ ./00-createdb.sh`
  - `# cd /opt/richmentdb`
  - `# ./update.sh`
    - It takes about 3 minutes. Take a CUP NOODLE ;-)
- USE IT!
  - `# ./mysql-console.sh`
  - `mysql> select count(*) from richment;`

# How2use

Execute `./mysql-console.sh` and query it!

- Use richment table on vulnrichment database.
  - ex) `> select count(*) from richment;`

A usage example is written in "EXAMPLE.md".

> [!NOTE]
> Due to RDBMS specifications, some dummy data is included.
> ; Because it cannot be null
> 
> - If there is no CVSS data, the score will be 0.
>   - adp31Score, cna31Score, cna40Score (type; int)
> - If there is no KEV catalog data, the addition date will be "1900-01-01".
>   - adpKEVDateadded (type; date)

# Appendix
## directory/file structure

```
/richmentdb/
|-- README.md
|-- docker
|   `-- Dockerfile
|-- env
|   `-- my.cnf
|-- init-scripts
|   `-- 00-createdb.sh
|-- mysql-console.sh
|-- subprogram
|   `-- getdata.sh
`-- update.sh
```

- README.md
  - THIS FILE!
- EXSAMPLE.md
  - An example of its use in an SQL statement is provided.
- mysql-console.sh
  - open mysql console
  - it use env/my.cnf file
- update.sh
  - update database script
  - pull Vulnrichment, delete all mysql data, import all Vulnrichment json file data
  - it needs about 3 min
- docker/Dockerfile
  - docmer image build file
- env/my.cnf
  - mysql connection setting file
- init-scripts/00-createdb.sh
  - database creatinon file
  - run once on dockerfile
- subprogram/getdata.sh
  - database update sub program
  - Vulnrichment JSON file to CSV file
  - use on update.sh 
  - No need to use it manually

## vulnrichment database schema
Since it does not officially exist, I set the necessary parts appropriately.

|name|columnName|jsonData|type|note|
|:---|:---|:---|:---:|:---|
|CVE-ID|cveId|.cveMetadata.cveId|int auto_increment|note|
|CWE-ID|cweId|.containers.adp[]?.problemTypes[]?.descriptions[]?.cweId|varchar(30)|multiple values, separate them with spaces.|
|SSVC Exploitation|adpSSVCExploitation|.containers.adp[]?.metrics[]?.other? | select(.type=="ssvc") | .content?.options[0]?.Exploitation|varchar(6)|none/poc/Active|
|SSVC Automatable|adpSSVCAutomatable|.containers.adp[]?.metrics[]?.other? | select(.type=="ssvc") | .content?.options[1]?.Automatable|varchar(3)|yes/no|
|SSVC Technical Impact|adpSSVCTechImpact|.containers.adp[]?.metrics[]?.other? | select(.type=="ssvc") | .content?.options[2]?."Technical Impact"|varchar(7)|partial/Total|
|KEV Catalog add date|adpKEVDateadded|.containers.adp[]?.metrics[]?.other? | select(.type == "kev") | .content?.dateAdded|date|If not registered in KEV Catalog, set as 1900-01-01|
|KEV Catalog Reference|adpKEVRef|.containers.adp[]?.metrics[]?.other? | select(.type=="kev") | .content?.reference|varchar(2048)||
|richment CVSS v3.1 Score|adp31Score|.containers.adp[]?.metrics[]? | select(.cvssV3_1) | .cvssV3_1.baseScore|int|If there is no relevant data, set as 0.|
|richment CVSS v3.1 Severity|adp31Severity|.containers.adp[]?.metrics[]? | select(.cvssV3_1) | .cvssV3_1.baseSeverity|varchar(8)|(NULL)/NONE/LOW/MEDIUM/HIGH/CRITICAL|
|richment CVSS v3.1 Vector|adp31Vector|.containers.adp[]?.metrics[]? | select(.cvssV3_1) | .cvssV3_1.vectorString|varchar(130)||
|CNA release CVSS v3.1 Score|cna31Score|.containers.cna.metrics[]? | select(.cvssV3_1) | .cvssV3_1.baseScore|int|If there is no relevant data, set as 0.|
|CNA release CVSS v3.1 Severity|cna31Severity|.containers.cna.metrics[]? | select(.cvssV3_1) | .cvssV3_1.baseSeverity|varchar(8)|(NULL)/NONE/LOW/MEDIUM/HIGH/CRITICAL|
|CNA release CVSS v3.1 Vector|cna31Vector|.containers.cna.metrics[]? | select(.cvssV3_1) | .cvssV3_1.vectorString|varchar(130)||
|CNA release CVSS v4.0 Score|cna40Score|.containers.cna.metrics[]? | select(.cvssV4_0) | .cvssV4_0.baseScore|int|If there is no relevant data, set as 0.|
|CNA release CVSS v4.0 Severity|cna40Severity|.containers.cna.metrics[]? | select(.cvssV4_0) | .cvssV4_0.baseSeverity|varchar(8)|(NULL)/NONE/LOW/MEDIUM/HIGH/CRITICAL|
|CNA release CVSS v4.0 Vector|cna40Vector|.containers.cna.metrics[]? | select(.cvssV4_0) | .cvssV4_0.vectorString|varchar(130)||

ref.
- KEV Catalog schema
  - https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities_schema.json
- CVE Record Format
  - https://github.com/CVEProject/cve-schema/blob/master/schema/CVE_Record_Format.json
