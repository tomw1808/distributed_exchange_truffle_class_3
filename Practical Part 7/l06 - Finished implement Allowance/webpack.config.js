const path = require('path');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const webpack = require('webpack');

const bootstrapEntryPoints = require('./webpack.bootstrap.config.js');


// eslint-disable-next-line no-console
console.log(`=> bootstrap-loader configuration: ${bootstrapEntryPoints.dev}`);

module.exports = {
    entry: './app/javascripts/app.js',
    output: {
        path: path.resolve(__dirname, 'build'),
        filename: 'app.js'
    },
    plugins: [
        // Copy our app's index.html to the build folder.
        new CopyWebpackPlugin([
            {from: './app/index.html', to: "index.html"},
            {from: './app/trading.html', to: "trading.html"},
            {from: './app/managetoken.html', to: "managetoken.html"}
        ]),
        new webpack.ProvidePlugin({
            jQuery: 'jquery',
            $: 'jquery',
            jquery: 'jquery'
        })
    ],
    module: {
        rules: [
            {test: /\.css$/, use: ['style-loader', 'css-loader', 'postcss-loader']},
            {test: /\.scss$/, use: ['style-loader', 'css-loader', 'postcss-loader', 'sass-loader']},
            {
                test: /\.woff2?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
                use: 'url-loader?limit=10000',
            },
            {
                test: /\.(ttf|eot|svg)(\?[\s\S]+)?$/,
                use: 'file-loader',
            },

            // Bootstrap 3
            {test: /bootstrap-sass\/assets\/javascripts\//, use: 'imports-loader?jQuery=jquery'},

        ],
        loaders: [
            {test: /\.json$/, use: 'json-loader'},
            {
                test: /\.js$/,
                exclude: /(node_modules|bower_components)/,
                loader: 'babel-loader',
                query: {
                    presets: ['es2015'],
                    plugins: ['transform-runtime']
                }
            }
        ]
    }
}
