from mongo_access import MongoAccess
import bcrypt 
import jwt

class Auth(object):
    def __init__(self):
        self.collection = "credentials"
        self.mongo_acc = MongoAccess("users")

    def retrieve_user(self, id):
        return self.mongo_acc.get_doc_by_id(self.collection, id)
    
    def is_registered(self, id):
        return not self.retrieve_user(id) is None
    
    def register(self, id, pw):
        if self.is_registered(id):
            print("Already registered")
            return False
        bytes = pw.encode('utf-8') 
        salt = bcrypt.gensalt() 
        hash = bcrypt.hashpw(bytes, salt) 
        self.mongo_acc.insert_doc(self.collection, {"id" : id, "pw": hash, "salt": salt})
        return True

    def try_login(self, id, pw):
        user = self.retrieve_user(id)
        if user is None:
            print("Not registered")
            return None
        attempt = bcrypt.hashpw(pw.encode("utf-8"), user["salt"])
        if attempt != user["pw"]:
            print("Wrong pw")
            return None
        return jwt.encode({"id": id}, pw, algorithm="HS256")
        
    
if __name__ == "__main__":   
    auth = Auth()
    auth.register("user1", "aaa")
    auth.register("user1", "aaa")
    print(auth.try_login("user1", "bbb"))
    print(auth.try_login("user1", "aaa"))