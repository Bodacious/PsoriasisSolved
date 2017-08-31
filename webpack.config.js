// ================
// = Requirements =
// ================
const path              = require('path');
const autoprefixer      = require('autoprefixer');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const webpack           = require('webpack');
const coffee            = require('coffee');

// =============
// = Variables =
// =============
const nodeEnv      = process.env.NODE_ENV || 'development';
const isProduction = nodeEnv === 'production';
const buildPath    = path.join(__dirname, './dist');
const sourcePath   = path.join(__dirname, './src');

// =================
// = Configuration =
// =================
module.exports = {
  context: sourcePath,
  entry: path.join(__dirname, './src/js/index.js'),
  output: {
    path: path.join(__dirname, './dist'),
    filename: '[name]-[hash].js',
  },
  module: {
    rules:[
      {
        test: /\.(css|sass|scss)$/,
        use: ExtractTextPlugin.extract({
          fallback: 'style-loader',
          use: ['css-loader', 'sass-loader']
        })
      },
      {
        test: /\.coffee$/,
        exclude: /node_modules/,
        use: ['coffee-loader'],
      },
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          query: {
            presets: ['es2015']
          }
        }
      },
      {
        test: /\.(jpe?g|png|woff|woff2|eot|ttf|svg)(\?[a-z0-9=.]+)?$/,
        use:[{
          loader: 'url-loader',
          query: { limit: 100000 }
        }],
      }
    ]
  },
  plugins: [
    new ExtractTextPlugin({filename:'[name]-[contenthash].css'}),
    new webpack.optimize.UglifyJsPlugin({
      compress: {
        warnings: false,
      },
      output: {
        comments: false,
      },
    }),
    new HtmlWebpackPlugin({
      template: path.join(sourcePath, 'index.html'),
      path: buildPath,
      filename: 'index.html',
      minify: {
        removeAttributeQuotes: true,
        collapseWhitespace: true,
        html5: true,
        minifyCSS: true,
        removeComments: true,
        removeEmptyAttributes: true,
      },
      hash: true,
    }),
    new webpack.LoaderOptionsPlugin({
      options: {
        postcss: [
          autoprefixer({
            browsers: [
              'last 3 version',
              'ie >= 10',
            ],
          }),
        ],
        context: sourcePath,
      },
    }),
  ],

  devServer: {
    contentBase: isProduction ? './build' : './src',
    historyApiFallback: true,
    compress: !isProduction,
    inline: !isProduction,
    hot: !isProduction,
    port: 3000,
    stats: {
      assets: true,
      children: false,
      chunks: false,
      hash: true,
      modules: false,
      publicPath: false,
      timings: true,
      warnings: true,
    },
  }
};
