# Julie

JULIE stand for JUst a deLIghtful Encrypter

Julie is a small script used to send easly encrypted message

## How to use it ?

julie is working like that

To send something
```
julie-s -r [recipient]
```
[recipient] must be the name of a gpg key that you already added

To receive something
```bash
julie-r [key]
```

## How to install it ?

### Arch
If you are on arch it's simple : install the package julie with your favorite AUR helper

### Other
Just do
```bash
git clone https://framagit.org/SirCipherz/julie.git
cd julie
sudo ./install.sh
```

## Options

### Send
```
-e        : Override the editor
-r        : Recipient (can be ID, Name, email)
-h        : Shows help
-i <path> : Send an image
```
### Receive
```
-t       : Change the tmp dir
-e       : Override the editor
-h       : Shows help
```
## How much secure is Julie ?

Julie use gpg which is a very strong encryption software in addition the encrypted messages are sent on file.io in base64 with a 1 day download limit. You can use Julie without any fear, security is very important to her devlopper.

## How to contribute ?

- You can make forks of Julie to improve her code
- You can submit issues if you want me to fix it
- You can send feedbacks and suggestions too
- Finally you can talk to your friends about Julie
