cd ~/EDAMAME_16S/Fastq

echo "Running fastqc..."
~/FastQC/fastqc *.fastq
mkdir -p ~/EDAMAME_16S/results/fastqc

echo "saving..."
mv *.zip ~/EDAMAME_16S/results/fastqc/
mv *.html ~/EDAMAME_16S/results/fastqc/

cd ~/EDAMAME_16S/results/fastqc/

echo "Unzipping..."
for zip in *.zip
do
  unzip $zip
done

echo "saving..."
cat */summary.txt > ~/EDAMAME_16S/results/fastqc_summaries.txt
