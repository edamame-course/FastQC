#Assessing the quality of raw amplicon sequencing data
Authored by Siobhan Cusack, with contributions from Ashley Shade and Jackson Sorensen for EDAMAME2016.

**The shell script included in this tutorial is from [Data Carpentry](http://www.datacarpentry.org/2015-08-24-ISU/lessons/08-automating_a_workflow.html)**
####Information in this tutorial is based on the FastQC manual which can be accessed [here](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/3%20Analysis%20Modules/).
[EDAMAME-2016 wiki](https://github.com/edamame-course/2016-tutorials/wiki)

***
EDAMAME tutorials have a CC-BY [license](https://github.com/edamame-course/2015-tutorials/blob/master/LICENSE.md). _Share, adapt, and attribute please!_
***

##Overarching Goal
* This tutorial will contribute towards an understanding of **microbial amplicon analysis**

##Learning Objectives
* Understand the information provided in Illumina "raw" fastq files
* Install auxiliary software on an EC2 instance
* Use FastQC to assess the overall quality of raw sequencing data, and determine the parameters that are important specifically to metagenomes
* Understand how to write and execute a shell script

***

#Data quality checking with FastQC

The purpose of this tutorial is to get you thinking about the quality of the (Illumina) data that you get back from the sequencing facility. This is important because you don't want to waste your valuable time analyzing data that are terrible quality.
The program we'll be using to check the quality of our Centralia data is called FastQC. Usually you would want to trim off the primers before using FastQC, but our sequencing facility already did the primer trimming for us. But before we start quality checking, we're going to look at the fastq files that we got back from the sequencing facility. 

##1. What's in a Fastq file?
First we'll need to start and connect to an Amazon EC2 instance like we [did yesterday](http://angus.readthedocs.io/en/2015/amazon/index.html). 

Once we are connected to the instance, we'll wget the Centralia data. 

```
wget https://s3.amazonaws.com/edamame/EDAMAME_16S.tar.gz
tar -zxvf EDAMAME_16S.tar.gz

```

Inspect the raw data files.  What do the guts of a fastq file look like?

```
cd EDAMAME_16S/Fastq
more C01D01F_sub.fastq
```

Each fastq has four lines:
* 1. name (header - includes sequencer, spot coordinates, flow cell, etc...)   
* 2. actual sequence data   
* 3. spacer (starts with +)   
* 4. Quality: q score - alphanumeric (I is a score of 40, which is a perfect score) see [Wikipedia link](http://en.wikipedia.org/wiki/FASTQ_format) (no kidding!) for interpretation of alphanumeric Q score.

Can you identify each of the above components in the first fastq file? (Use ```q``` to exit ```more```).

A good sequencing center should return some information on how the sequencing went and the proprietary software they used to do some initial quality control of the raw data, and, potentially, information about de-multiplexing.  You can look at the info we got from the MSU Genomics Core [here](https://github.com/edamame-course/2015-tutorials/tree/master/demos/QCRawTags).


##2. Acquiring and executing FastQC
Now that we have an idea of the data we're working with, we'll use FastQC to check the quality. But FastQC doesn't come pre-loaded on the EC2 instance! Never fear, we can install auxiliary software on the EC2. We'll navigate to the home directory for this install, then `wget` the appropriate file. 
```
cd 
wget http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip
```
Now we have the program file in the home directory. Since it's all zipped up and currently unusable, let's unzip it.

```
unzip fastqc_v0.11.5.zip
```
This will create a new directory called FastQC with all of the program files in it. We need to change the permissions on the executable file in order to run the program.

```
cd FastQC
chmod 755 fastqc
```
Now we can execute the file. If you're interested in the specifics of changing file permissions, there is a 10 second crash course [here](https://files.fosswire.com/2007/08/fwunixref.pdf) under the heading "File Permissions".

Install java on the EC2
```
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install oracle-java7-installer
```

We're ready to check the quality of our data! What do we need to do?
* Navigate to the directory containing our fastq files
* Execute the FastQC program on one of our files
* See what the output of FastQC is

```
cd ~/EDAMAME_16S/Fastq
~/FastQC/fastqc C01D01F_sub.fastq
ls
```
If you look towards the top of the list of files in the Fastq directory, you will see that for the original fastq file, C01D01F_sub.fastq, there are two new files with the same naming convention but with endings `fastqc.html` and `.fastqc.zip`. Let's unzip this file and take a look. 

```
unzip C01D01F_sub_fastqc.zip
ls C01D01F_sub_fastqc
head C01D01F_sub_fastqc/summary.txt
```

This will show a summary of each quality checking module in the middle column, whether the file passed or failed this check in the left column, and the sequencing file name in the right column. This is useful if you want to quickly check on the results of many sequencing files at once. But since this is just a summary, there is still much more information to be gleaned from the results. Let's take a look at the html file to see what the full FastQC output looks like. 

##3. SCP
In order to do this, we're going to transfer the html file from the cloud computer to our local computer. We'll do this using ```scp```, which stands for "secure copy". 
Open a new terminal window on your computer (not the EC2 instance window). Using scp, transfer the html file from the first sequencing file to your desktop. The syntax of this command is similar to the `ssh` that we use to connect to the cloud computer, but in this case we also have to specify:
* The exact path of the file on the cloud computer that we want to transfer
* The exact path on the local computer where we want the file transferred to

Here's what that looks like:
```
scp -i ~/Directory/YOURKEY.pem ubuntu@YOURINSTANCEID.amazonaws.com:/home/ubuntu/EDAMAME_16S/results/fastqc/C01D01F_sub_fastqc.html ~/Desktop
```
If you execute the command above, this will transfer C01D01F_sub_fastqc.html to your desktop. Once the file has transferred successfully, double-click on the file and it should open in your browser.

##4. FastQC Results 
On the left-hand side of the screen, there will be a summary of the analyses with some combination of green checkmarks, yellow exclamation points, and red Xs, depending on whether or not the sequences pass the quality check for each module.

###1: Basic Statistics
![basic statistics](/img/basic_statistics.png)

Basic statistics displays a chart containing information about your file, including the name, how many reads were analyzed, and whether or not any of the reads were flagged for poor quality. In this case, we had 10,000 sequences. None of them were flagged as poor quality. The average sequence length was 150 bases, with 51% GC content.

###2: Per base sequence quality
![per base sequence quality](/img/per_base_seq_qual.png)

First, a word about the y-axis units: In this graph, as in many others to follow, sequence quality is denoted as a [Phred score](https://en.wikipedia.org/wiki/Phred_quality_score). The scale is logarithmic and spans values 0-40. The maximum Phred score of 40 indicates an error rate of 1 base in 10,000, or an accuracy of 99.99%. A Phred score of 30 indicates an error rate of 1 base in 1000, or an accuracy of 99.9%. 
For the more visual learners among us, here is a graph demonstrating the relationship between Phred scores and error rate.
![phred scores](/img/phred_scores.png)

Per base sequence quality shows the quality of the sequences in your file at every base position. In our case, this is from 1 to 150. This module displays the information using box and whisker plots to give a sense of how much variation there was among the reads. Ideally we would want the entire plot to be contained within the green region; this would be considered very good quality. While having part of the plot in the orange or red regions is not preferable, sequences can still pass the quality check if this is the case, as in our example. When the lower quartile for any position is less than 10 or the median is less than 25, the module will give a warning. When the lower quartile for any position is less than 5 or the median is less than 20, the sequence will fail this quality check.


###3: Per tile sequence quality
![per tile sequence quality](/img/per_tile_seq_quality.png)

Per tile sequence quality is a heatmap display of the flow cell quality by individual tiles. If the figure is a solid bright blue, the flow cell tile quality was consistently great! If there are patches of lighter blue or any other color, there was a problem associated with one of the tiles (such as a bubble or smudge) and this may correspond with a decrease in sequence quality in those regions. Above you can see some light blue, green, and yellow patches, as well as one orange square, which all indicate potential problems with the sequencing lane. The presence of so many green to orange squares has resulted in a warning for this module. It would be more concerning if we had more orange or any red tiles. 

###4: Per sequence quality scores
![per sequence quality scores](/img/per_seq_qual.png)

Per sequence quality scores represent the quality of each read. The y-axis is number of sequences, and the x-axis uses Phred scores as described in section 2. Sequences will yield a warning for this module if there is an error rate of 0.2% or higher (Phred score below 27). Sequences will fail this quality check if they have an error rate of 1% or higher (Phred score below 20.)
In our example, the average quality per read is 37, which is very good; this represents an accuracy of 99.98%. 

###5: Per base sequence content
![per base sequence content](/img/per_base_seq_content.png)

Per base sequence content shows, for each position of each sequence, the base composition as a percentage of As, Ts, Cs and Gs. This module will yield a warning if the base content varies more than 10% at any position, and a sample will fail if there is more than 20% variation at any position, as in the example above. However, FastQC is designed for checking whole genome sequencing data, but we used 16S sequences for our input files. So although we have a failure for this module, it's not because there's something wrong with our sequences. It's simply because we used sequences that are enriched for certain bases, rather than completely random sequences from a whole genome.

###6: Per sequence GC content
![per sequence GC content](/img/per_seq_GC_content.png)

Per sequence GC content displays the GC content for all reads along with the "theoretical distribution" of GCs. The peak of the red line corresponds to the mean GC content for the sequences, while the peak of the blue line corresponds to the theoretical mean GC content. Your GC content should be normally distributed; shifts in the peak are to be expected since GC content varies between organisms, but anything other than a normal curve might be indicative of contamination. The sharp peak seen above is again due to the fact that we have enriched for a specific sequence, so we expect the majority to have about the same GC content. 
A warning is raised if sequences outside of the normal distribution comprise more than 15% of the total. A sample will fail if more than 20% of sequences are outside the normal distribution. Failures are usually due to contamination (frequently by adapter sequences), or to the use of amplicons as we have done here. 

###7: Per base N content
![per base N content](/img/per_base_N_content.png)

Per base N content shows any positions within the sequences which the which have not been called as A, T, C or G. Ideally the per base N content will be a completely flat line at 0% on the y-axis, indicating that all bases have been called. Samples receive a warning if the N content is 5% or greater, and will fail if N content is 20% or greater. Our example shows the ideal result for this module!

###8: Sequence length distribution
![sequence length distribution](/img/seq_length_dist.png)

This module simply shows the length of each sequence in the sample. Depending on the sequencing platform used, this will vary. For Illumina sequencing, each read should be the same size, with variation of one or two bases being acceptable. For other platforms, a relatively large amount of variation is normal. The module will show a warning if there is any variation in sequence length, which can be ignored if you know that this is normal for your data. A failure here means that at least one sequence had a length of 0. Our example passes this module as all of the sequences are 150 bp with no variation.

###9: Sequence duplication levels
![sequence duplication levels](/img/seq_duplication.png)

The sequence duplication levels plot shows the number of times a sequence is duplicated on the x-axis with the percent of sequences showing this duplication level on the y-axis. Normally a genome will have a sequence duplication level of 1 to 3 for the majority of sequences, with only a handful having a duplication level higher than this; the line should have an inverse log shape. A high duplication level for a large percentage of sequences is usually indicative of contamination. Once again we see that the use of 16S sequencing data yields confusing results; the above result is normal considering the input sequences. This module will issue a warning if more than 20% of the sequences are duplicated, and a failure if more than 50% of the sequences are duplicated. A warning or failure can also result from PCR artifacts.

###10: Overrepresented sequences
![overrepresented sequences](/img/overrep_seqs.png)

If a certain sequence is calculated to represent more than 0.1% of the entire genome, it will be flagged as an overrepresented sequence and yield a warning for this module. The presence of sequences that represent more than 1% of the whole genome will result in a failure, as seen above.
These overrepresented sequences are seen because we are looking at 16S data; if we did not see this many overrepresented sequences, there would be a serious problem. Another frequent source of "overrepresented sequences" is Illumina adapters, which is why it's a good idea to trim sequences before running FastQC.

The program searches for possible matches to identified overrepresented sequences; although this search frequently returns "no hit" (as seen in our example), it is usually quite easy to identify the overrepresented sequences by doing a BLAST search.


###11: Adapter content
![adapter content](/img/adapter_content.png)
This module searches for specific adapter sequences. A sequence that makes up more than 5% of the total will cause a warning for this module, and a sequence that makes up more than 10% of the total will cause a failure. Our example shows no contamination with adapter sequences, which is ideal. If there were a significant number of adapter sequences present, we would want to use a trimming program to remove them before further analysis.



###12: Kmer content
![kmer_content](/img/Kmer_content.png)


In a completely random library, any kmers would be expected to be seen about equally in each position (from 1-150 in this case). Any kmers that are specifically enriched at a particular site are reported in this module. If a kmer is enriched at a specific site with a p-value of less than 0.01, a warning will be displayed. A failure for this module occurs if a kmer is enriched at a site with a p-value of less than 10^-5.
We have failed this module, again due to the fact that we are using 16S sequences. As with the overrepresented sequences, we are expecting to see well-represented kmers because of high sequence conservation in the 16S region.
In non-enriched reads, it is relatively common to see highly represented kmers near the beginning of a sequence if adapters are present.

##5. Automation
If we were to do all of this quality checking manually, we would have to run FastQC on each of our 104 sample files individually. This is a time-consuming and repetitive task, so we're going to automate this process. 
We'll navigate to the home directory, grab an executable file, change the permissions, and run it. 

```
cd
wget https://raw.githubusercontent.com/edamame-course/FastQC/master/Fastqc_automation.sh
chmod 755
./Fastqc_automation.sh
```
This will take several minutes to run on all of the files. Once it finishes, we'll look at the output.

```
cd EDAMAME_16S/results/fastqc
ls
```

FastQC has been run on all of our files. How did we do this?
We used a [shell script](https://en.wikipedia.org/wiki/Shell_script)! Open up the shell script and see if you can figure out what it's doing.

```
cd 
nano Fastqc_automation.sh
```

To look at an overall summary of our sequencing quality, we can look at the summary file our shell script created. 
```
cd ~/EDAMAME_16S/results
more fastqc_summaries.txt
```


###For additional FastQC questions, check the [documentation](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/). Happy quality checking!

***
##Help and other Resources
* [FastQC web documentation](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
* [Data Carpentry tutorial](http://www.datacarpentry.org/2015-08-24-ISU/lessons/08-automating_a_workflow.html) on shell scripts for automating workflows such as this one
