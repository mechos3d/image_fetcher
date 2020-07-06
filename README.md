# Image fetcher cli

The application takes a plaintext file containing URLs, one per line, and downloads them storing on the local hard disk.
The second argument is path to the directory where images are to be saved.

Usage example: 
given a file:
```
echo "https://foo.com/one.jpg\nhttps://bar.net/two.png" > input_file
```
calling the script: 
```
./bin/image_fetcher ./out_directory input_file
```
will lead to 'out_directory' being created (if it doesn't exist yet) and images saved there: 
```
ls ./out_directory
> 68bf8c6bd1a48945222a8be378cf4883__one.jpg
  6d41855c786c806918e8b8f8c5239f6c__two.png
```
The application uses MD5 hash of the full url to ensure uniqueness of filenames
Existing files with the same name are not overwriten and are considered an error.
Downloading uses upto 50 threads (it's hardcoded for now)

