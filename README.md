# FMDBDemoSvn
使用FMDB操作数据库，使用反射将model自动创建数据库表格，并提供数据库增删改查各种接口。
使用时只需要将您的model类继承Base model ，model属性提供get set 或者@synthesize即可。
-(NSString *)compareProperty:(NSString*) property 方法提供了model类型和sqlite类型对应关系。您可以自行修改。
