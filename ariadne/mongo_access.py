import os
from dotenv import load_dotenv
from pymongo import MongoClient

load_dotenv()

MONGO_URL = os.getenv('MONGO_URL')



class MongoAccess(object):
    def __init__(self, database_name, mongo_url = MONGO_URL):
        self.mongo_url = mongo_url
        CONNECTION_STRING = self.mongo_url
        self.client = MongoClient(CONNECTION_STRING)[database_name]

   
    def get_collection_items(self, collection_name):
        return [i for i in self.client[collection_name].find()]
    
    
    def insert_doc(self, collection, doc):
        self.client[collection].insert_one(doc)

    def get_doc_by_id(self, collection, id):
        query = {"id" : id}
        res = self.client[collection].find_one(query)
        return res


if __name__ == "__main__":   
    dbname = "users"
    user_db = MongoAccess(dbname, MONGO_URL)
    print(user_db.get_collection_items("credentials"))
    user_db.insert_doc("credentials", {"id" : "user1", "pw" : "aaa"})
    print(user_db.get_collection_items("credentials"))
