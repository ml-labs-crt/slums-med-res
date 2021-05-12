## Mapping Slums with Medium Resolution Satellite Imagery: a Comparative Analysis of Techniques using Multi-Spectral Data and Grey-level Co-occurrence Matrix

This repo contains the code to reproduce the results obtained on the paper "Mapping Slums with Medium Resolution Satellite Imagery: a Comparative Analysis of Techniques using Multi-Spectral Data and Grey-level Co-occurrence Matrix".

## Files

- ```GLCM+CCF_majorityNonSlum.R``` and ```GLCM+CCF_majoritySlum.R``` have the code to create the Grey-level Co-occurrence Matrix features and classify the images using Canonical Correlation Forests. 
- ```Spectral+CCF__majorityNonSlum.R``` and ```Spectral+CCF_majoritySlum.R``` have the code to classify the images using multi-spectral data and Canonical Correlation Forests. 

## Dataset 

The dataset used in this study is available at: [https://drive.google.com/drive/folders/1yhDwR4zyPQO78x040uGCPqFarTDQ3yQm](https://drive.google.com/drive/folders/1yhDwR4zyPQO78x040uGCPqFarTDQ3yQm).

If using the dataset, please cite:

```
@inproceedings{gram-hansenMappingInformalSettlements2019,
	address = {New York, NY, USA},
	series = {{AIES} '19},
	title = {Mapping {Informal} {Settlements} in {Developing} {Countries} using {Machine} {Learning} and {Low} {Resolution} {Multi}-spectral {Data}},
	doi = {10.1145/3306618.3314253},
	booktitle = {Proceedings of the 2019 {AAAI}/{ACM} {Conference} on {AI}, {Ethics}, and {Society}},
	publisher = {Association for Computing Machinery},
	author = {Gram-Hansen, Bradley J. and Helber, Patrick and Varatharajan, Indhu and Azam, Faiza and Coca-Castro, Alejandro and Kopackova, Veronika and Bilinski, Piotr},
	month = jan,
	year = {2019},
	pages = {361--368}
```




