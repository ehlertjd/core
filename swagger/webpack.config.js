var path = require('path');
var CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = {
	entry: './swagger-ui/swagger-ui.js',
	output: {
		filename: 'bundle.js',
		path: path.resolve('dist/')
	},
	plugins: [
		new CopyWebpackPlugin([
			{from:'swagger-ui/index-webpack.html', to:'index.html'},
			{from:'node_modules/swagger-ui-dist/*.png', flatten:true},
			{from:'node_modules/swagger-ui-dist/*.css', flatten:true}
		])
	]
};

