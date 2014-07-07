module Graphics.D3.Examples.BarChart2 where

import Data.Either
import Data.Maybe
import Data.Array (length)
import Data.Traversable
import Data.Foreign
import Data.Foreign.EasyFFI

import Graphics.D3.Base
import Graphics.D3.Util
import Graphics.D3.Selection
import Graphics.D3.Scale
import Graphics.D3.Request
import Graphics.D3.SVG.Axis

-- | This is a PureScript adaptation of part 2 of Mike Bostock's "Let's Make a Bar Chart" series:
-- | http://bost.ocks.org/mike/bar/2/

{-

Original JavaScript code:
=========================

var width = 420,
    barHeight = 20;

var x = d3.scale.linear()
    .range([0, width]);

var chart = d3.select(".chart")
    .attr("width", width);

d3.tsv("data.tsv", type, function(error, data) {
  x.domain([0, d3.max(data, function(d) { return d.value; })]);

  chart.attr("height", barHeight * data.length);

  var bar = chart.selectAll("g")
      .data(data)
    .enter().append("g")
      .attr("transform", function(d, i) { return "translate(0," + i * barHeight + ")"; });

  bar.append("rect")
      .attr("width", function(d) { return x(d.value); })
      .attr("height", barHeight - 1);

  bar.append("text")
      .attr("x", function(d) { return x(d.value) - 3; })
      .attr("y", barHeight / 2)
      .attr("dy", ".35em")
      .text(function(d) { return d.value; });
});

function type(d) {
  d.value = +d.value; // coerce to number
  return d;
}

-}

type NameAndValue = { name :: String, value :: Number }

coerceNameAndValue :: forall a. a -> D3Eff NameAndValue
coerceNameAndValue = unsafeForeignFunction ["x", ""] "{ name: x.name, value: Number(x.value) }"

width = 420
barHeight = 20

main = do

  xScale <- linearScale
    .. range [0, width]

  chart <- rootSelect ".chart"
    .. attr "width" (const width)

  tsv "data/namesAndNumbers.tsv" \(Right array) -> do
    typedData <- traverse coerceNameAndValue array

    xScale ... domain [0, maxBy (\d -> d.value) typedData]
    x <- freeze xScale

    chart ... attr "height" (const $ barHeight * length typedData)

    bar <- chart ... selectAll "g"
        .. bind typedData
      .. enter .. append "g"
        .. attr' "transform" (\_ i -> "translate(0," ++ show (i * barHeight) ++ ")")

    bar ... append "rect"
      .. attr "width" (\d -> x d.value)
      .. attr "height" (const $ barHeight - 1)

    bar ... append "text"
      .. attr "x" (\d -> x d.value - 3)
      .. attr "y" (const $ barHeight / 2)
      .. attr "dy" (const ".35em")
      .. text (\d -> show d.value)
