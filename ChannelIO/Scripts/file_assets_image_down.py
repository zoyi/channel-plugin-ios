import json
import re
import os
import urllib
import shutil

ASSET_URL = "http://bin.exp.channel.io/asset/file-icon/"
FILE_NAME = "extensions.json"

PROJECT_DIR = os.getcwd()
TYPES_JSON = os.path.join(PROJECT_DIR, 'ChannelIO/Assets/{}'.format(FILE_NAME))
IMAGE_DIR = os.path.join(PROJECT_DIR, 'ChannelIO/Assets/Images.xcassets')

# download FILE_NAME.json
urllib.urlretrieve(ASSET_URL + FILE_NAME, TYPES_JSON)

# download file image asstes
with open(TYPES_JSON) as text:
    types = text.read()
    p = re.compile('"key": ?"(.*)",')
    keys = p.findall(types)
    os.chdir(IMAGE_DIR)
    for key in keys:
        key_path = os.path.join(IMAGE_DIR, "{}.imageset".format(key))
        if os.path.exists(key_path) and os.path.isdir(key_path):
            shutil.rmtree(key_path, ignore_errors=True)
        os.mkdir(key_path)
        urllib.urlretrieve(ASSET_URL + '{}.png'.format(key), os.path.join(key_path, "{}.png".format(key)))
        urllib.urlretrieve(ASSET_URL + '{}@2x.png'.format(key), os.path.join(key_path, "{}@2x.png".format(key)))
        urllib.urlretrieve(ASSET_URL + '{}@3x.png'.format(key), os.path.join(key_path, "{}@3x.png".format(key)))
        contents_file_path = os.path.join(key_path, "Contents.json")
        fid = open(contents_file_path, "w")

        contents = {}

        images = []
        file1 = {}
        file1["idiom"] = "universal"
        file1["filename"] = "{}.png".format(key)
        file1["scale"] = "1x"
        file2 = {}
        file2["idiom"] = "universal"
        file2["filename"] = "{}@2x.png".format(key)
        file2["scale"] = "2x"
        file3 = {}
        file3["idiom"] = "universal"
        file3["filename"] = "{}@3x.png".format(key)
        file3["scale"] = "3x"
        images.extend((file1, file2, file3))
        contents["images"] = images

        info = {}
        info["version"] = 1
        info["author"] = "xcode"
        contents["info"] = info
        
        json_data = json.dumps(contents, indent=2)

        fid.write(json_data)
        fid.close()

