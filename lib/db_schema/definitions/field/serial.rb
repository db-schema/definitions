module DbSchema
  module Definitions
    module Field
      class SmallSerial < Base
        register :smallserial
      end

      class Serial < Base
        register :serial
      end

      class BigSerial < Base
        register :bigserial
      end
    end
  end
end
