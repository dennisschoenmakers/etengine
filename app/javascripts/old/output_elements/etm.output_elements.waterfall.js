function InitializeWaterfall(id,series,unit,axis_values,colors,labels,ticks){
  var bar_width = 25;
  var series_default;
  var xaxis;
  var y2axis;

  var max_value = axis_values[1];
  var min_value = axis_values[0];
  // var number_of_ticks = axis_values[2];
  // tick_number = 5;
  //  if (min_value == 0 ){
     // var extra_ticks  = Math.ceil((min_value * -1) / (max_value / tick_number));
  //    min_value =  (max_value / tick_number * extra_ticks );
  //    tick_number += (extra_ticks + 1);
  //  }
  //  else {
  //    tick_number = 6;
  //  }  
  y2axis = {
    min: min_value, // afhankelijk van positive ticks maken 2500 / 5 -> 1000 / 2 == 7
    // autoscale: true,
    numberTicks: ticks[0],
    max: max_value,  
    tickInterval: ticks[1],
    tickOptions:{
      formatString: '%.0f'+'&nbsp;'+unit,
      fontSize: font_size,
      markSize: 0
    }
  };
  
  xaxis = {
    renderer: $.jqplot.CategoryAxisRenderer, 
    ticks:labels,
    tickRenderer: $.jqplot.CanvasAxisTickRenderer,
    tickOptions: {
      angle: -90,
      fontSize: font_size,
      showGridline: false
    }
  };
  
  series_default = {
    shadow:shadow,
    renderer:$.jqplot.BarRenderer, 
    fillToZero: true,
    rendererOptions:{
      fontSize:font_size,
      waterfall: true,
      fillToZero: true,
      varyBarColor: true,
      useNegativeColors: false,
      barWidth: bar_width
    },
    pointLabels: {
      hideZeros: false,
      ypadding: -5,
      formatString: '%.0f'
    },
    yaxis:'y2axis'
  };
  
  $.jqplot(id, [series], {
    seriesColors: colors,
    grid: default_grid,
    seriesDefaults: series_default,
    axes:{
      xaxis: xaxis,
      y2axis: y2axis
    }
  });
}