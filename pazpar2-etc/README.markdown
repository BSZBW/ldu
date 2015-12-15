# Informations (part of a repository created by SUB Goettingen)

# Modifications of Index Data’s etc files for pazpar2
This repository contains modified copies of [Index Data](http://www.indexdata.com/)’s configuration files for pazpar2 from the [»etc« folder](http://git.indexdata.com/?p=pazpar2.git;a=tree;f=etc;) in the pazpar2 project.

## Content
### tmarc.xsl
Index Data’s great [tmarc.xsl](http://git.indexdata.com/?p=pazpar2.git;a=blob;f=etc/tmarc.xsl) maps from MARC 21 fields to the fields of pazpar2’s internal data model. A few refinements to the stylesheet are commited here. Notably:

* extraction of language codes from MARC 008 and 041
* DOI recognition, map MARC 024 with $2=doi and 856 to `doi`
* map names in MARC 700 with $4=aut to the `author` field and all other 700 fields to the new `other-person` field
* new field `series-title` with data from MARC 490 and better handling of multivolume works
* put auxiliary information about URLs into their metadata tags attributes rather than into separate metadata tags
* map more MARC 5XX fields to `description`
* map MARC 520 with ind1=3 to `abstract` field
* classification information:
	* map MARC 082 to the `classification-ddc` field
	* map MARC 084 to the `classification-XXX` field where `XXX`is the classification name given in $2
* media types:
	* improved microform recognition
	* change thesis media type to manuscript
	* add multivolume media type for the record belonging to a multivolume work rather than single volumes
	* add multiple media type for mixed media
	
#### included in pazpar2 master branch now
* refined analysis of MARC 773 with journal information for articles


### solr-pz2.xsl
Rewrite of [Index Data’s solr-pz2.xsl](http://git.indexdata.com/?p=pazpar2.git;a=blob;f=etc/solr-pz2.xsl;h=b5d2f75a75c169356e870b0a122370ebea54327a;hb=HEAD) for converting Solr Documents to records of pz:metadata elements.
* more generic structure
* handles more field types
* does not introduce a »medium« field

### NEW! summon-pz2.xsl
Converting Summon Documents to records of pz:metadata elements.

### NEW! ebsco-pz2.xsl
Converting EDS/EBSCO Documents to records of pz:metadata elements.

### check-pazpar2.sh
Addition of `-P` parameter to query pazpar2 at a specific path on the server.


## Contact
For corrections, questions or suggestions please get in touch with [Sven-S. Porst](mailto:porst@sub.uni-goettingen.de) at SUB Göttingen, or fork the repository and push your changes.
