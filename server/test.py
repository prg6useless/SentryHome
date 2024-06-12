import firebase_admin
from firebase_admin import credentials, storage
from firebase_admin import firestore

# Use a service account.
cred = credentials.Certificate('serviceAccountkey.json')

app = firebase_admin.initialize_app(cred)

db = firestore.client()
# bucket = storage.bucket()

# file_name = "test.html"

# blob = bucket.blob(file_name)

# blob.upload_from_filename(file_name)
# blob.make_public()

# print("File Uploaded")

# doc_ref = db.collection("test").document("one")
# doc_ref.set({"first": "Ada", "last": "Lovelace", "born": 1815})

read_red = db.collection("Users")
docs = read_red.stream()
for doc in docs:
    print(doc.to_dict())
