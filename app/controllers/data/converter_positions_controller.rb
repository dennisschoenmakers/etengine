class Data::ConverterPositionsController  < Data::DataController

  def create
    if params[:converter_positions]
      params[:converter_positions].each do |converter_id,attributes|
        if bcp = ConverterPosition.find_by_converter_id(converter_id)
          bcp.update_attributes attributes
        else
          ConverterPosition.create attributes.merge(:converter_id => converter_id)
        end
      end
    end
    render :text => ''
  end

end
