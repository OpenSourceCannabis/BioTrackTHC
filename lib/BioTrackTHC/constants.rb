module BioTrackTHC
  module Constants
    module ResponsePage
      SAMPLE_ATTR            = { 'c' => 'date', 'd' => 'product', 'e' => 'quantity' }
      BUTTON_RECEIVE         = 'input[value="Receive Sample"]'
      BUTTON_RESULTS         = 'input[value="Add Results"]'
      BUTTON_ACTION_IDX      = 'input#button-IDX'
      UI_ELEMENTS            = ('b'..'e')
      LOT_BATCH_COLUMN_COUNT = 3
      UI_ELEMENT_IDX         = '.ui-block-IDX'
      DATA_ELEMENT           = '.ui-bar-e'
      SAMPLE_ID_OFFSET       = 0
      LOT_ID_OFFSET          = 2
      DATA_OFFSET            = 2
    end

    module API
      LOGIN_PAGE      = '/qlogin.asp'.freeze
      LICENSEE_SEARCH = '/qasearch.asp?style=full&maxRows=10&name_startsWith='.freeze
      LICENSE_SEARCH  = '/qasearchreturn.asp?l='.freeze
      SAMPLE_SEARCH   = '/qasearchreturn_lot.asp?l='.freeze
      SAMPLE_RECEIVE  = '/labtestreceive.asp?id='.freeze
      CREATE_RESULTS  = '/labtestresult.asp?id='.freeze
      UPDATE_RESULTS  = '/labtestresult_modify.asp?id='.freeze
      RECEIVE_PAGE    = '/labtestreceive.asp?id='.freeze
    end

    ANALITES = [
      :b_moisture,
      :c_thc,
      :c_thca,
      :c_thc,
      :c_cbd,
      :c_cbda,
      :c_cbd,
      :v_stems,
      :v_other,
      :m_aerobic_count,
      :m_yeast_mold,
      :m_total_coliform,
      :m_btgn_bacteria,
      :m_ecoli,
      :mycotoxins_pass,
      :pesticide_pass,
      :heavy_metal_pass,
      :amount_destroyed_pct,
      :amount_other_pct
    ]

  end
end
