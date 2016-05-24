# encoding: UTF-8
require 'spec_helper'

describe LibMsPack do

    describe '.MsPackSelfTest' do
        it 'should pass' do
            expect(LibMsPack.SysSelfTest).to eq(LibMsPack::MSPACK_ERR_OK)
        end
    end

    describe '.Version' do
        it 'should return LIBRARY version' do
            expect(LibMsPack.Version(LibMsPack::MSPACK_VER_LIBRARY)).to eq(1)
        end

        it 'should return SYSTEM version' do
            expect(LibMsPack.Version(LibMsPack::MSPACK_VER_SYSTEM)).to eq(1)
        end

        it 'should return MSCHMD version' do
            expect(LibMsPack.Version(LibMsPack::MSPACK_VER_MSCHMD)).to eq(2)
        end
    end

end

