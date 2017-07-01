import FluentProvider
import PostgreSQLProvider
import AuthProvider

weak var config: Config!

extension Config
{
    public func setup() throws
    {
        config = self
        
        Node.fuzzy = [Row.self, JSON.self, Node.self]
        
        try setupProviders()
        try setupPreparations()
    }
    
    private func setupProviders() throws {
        addConfigurable(middleware: HerokuHttpsMiddleware.init, name: "heroku-https")
        try addProvider(AuthProvider.Provider.self)
        try addProvider(PostgreSQLProvider.Provider.self)
        try addProvider(FluentProvider.Provider.self)
    }
    
    private func setupPreparations() throws
    {
        preparations.append(User.self)
        preparations.append(AccessToken.self)
    }
}
