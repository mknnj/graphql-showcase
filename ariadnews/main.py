from ariadne import SubscriptionType, gql, QueryType
from ariadne import make_executable_schema
from ariadne.asgi import GraphQL
from ariadne.asgi.handlers import GraphQLTransportWSHandler
import asyncio

query = QueryType()

type_defs = gql("""
                
   type Query {
        welcomeMessage: String!
    }

    type Subscription {
        counter: Int!
    }
                
""")


async def counter_generator(obj, info):
    for i in range(5):
        await asyncio.sleep(1)
        yield i


def counter_resolver(count, info):
    return count + 1


@query.field("welcomeMessage")
def resolve_login(_, info):
    return "Hello world, this is a welcome message"

subscription = SubscriptionType()
subscription.set_field("counter", counter_resolver)
subscription.set_source("counter", counter_generator)

schema = make_executable_schema(type_defs, [query, subscription])



graphql_app = GraphQL(
    schema,
    websocket_handler=GraphQLTransportWSHandler(),
)