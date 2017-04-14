module BioTrackTHC
  module Constants
    module ResponsePage
      SAMPLE_ATTR = { 'c' => 'date', 'd' => 'product', 'e' => 'quantity' }
      BUTTON_RECEIVE = 'input[value="Receive Sample"]'
      BUTTON_RECEIVE_IDX = 'input#button-IDX'
      UI_ELEMENTS = ('b'..'e')
      LOT_BATCH_COLUMN_COUNT = 3
      UI_ELEMENT_IDX = '.ui-block-IDX'
      DATA_ELEMENT = '.ui-bar-e'
      SAMPLE_ID_OFFSET = 0
      LOT_ID_OFFSET = 2
      DATA_OFFSET = 2
    end
  end
end
