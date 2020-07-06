# Image fetcher cli

The application takes a plaintext file containing URLs, one per line, and downloads them storing on the local hard disk.
The first argument is path to the directory where images are to be saved.
The second and all the following arguments - is a list of files with URLs

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

More than one input_file can be used, the script with process all of them:
```
./bin/image_fetcher ./out_directory input_file1 input_file2
```

Also it's possible to send urls to the script using a pipe:
```
echo "https://foo.com/one.jpg\nhttps://bar.net/two.png" | ./bin/image_fetcher ./out_directory
```

The application uses MD5 hash of the full URL to ensure uniqueness of filenames.          
Existing files with the same name are not overwriten and are considered an error.           
Downloading uses upto 50 threads (it's hardcoded for now)


## TODOS:

* Add `-h / --help` flag ( application just prints to STDOUT how is it to be used )
* Filename in URL can be very long - it's better to shorten them while constructing filename in local filesystem.
* Move directory creation code outside of the MainProcessor class to CliEndpoint and rescue 'Errno::EPERM' there
* Make threadpool settings (primarily max_threads) configurable - either through some cli flag or environment variables.
* For usability - better to create a subfolder for each domain and places this domain's images there.
* If the user did not provide output_directory as an argument - the script can create a default one instead (make 'output_directory' argument optional).
* Allow a list of URLs separated by spaces, not just newlines - it's more more usefull when working with pipes 

