from ariadne import QueryType, gql, MutationType
from ariadne import make_executable_schema
from ariadne.asgi import GraphQL
from authentication import Auth


query = QueryType()
mutation = MutationType()
auth = Auth()

type_defs = gql("""
                
    type Query {
        login(username: String!, password: String!): LoginResult!
        isRegistered(username: String!): Boolean!
    }

    type Mutation {
        register(username: String!, password: String!): Boolean!
    }
                
    type User {
        id: String!
        pw: String!
    }
                
    type LoginResult{
        isLoggedIn: Boolean!
        jwt: String
        reason: String
    }
                
""")


@query.field("login")
def resolve_login(_, info, username, password):
    r = auth.try_login(username, password)
    if r is None:
        return {
            "isLoggedIn" : False,
            "reason" : "wrong pw or user does not exist"
        }
    else:
        return{
            "isLoggedIn" : True,
            "jwt" : r
        }
    
@query.field("isRegistered")
def resolve_login(_, info, username):
    return auth.is_registered(username)
    
@query.field("isRegistered")
def resolve_login(_, info, username):
    return auth.is_registered(username)
    
@mutation.field("register")
def resolve_login(_, info, username, password):
    return auth.register(username, password)
    


schema = make_executable_schema(type_defs, [query, mutation])
app = GraphQL(schema, debug=True)