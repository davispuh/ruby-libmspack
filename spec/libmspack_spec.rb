# encoding: UTF-8
require 'spec_helper'

describe LibMsPack do

    describe '.MsPackSelfTest' do
        it 'should pass' do
            LibMsPack.SysSelfTest.should eq(LibMsPack::MSPACK_ERR_OK)
        end
    end

    describe '.Version' do
        it 'should return LIBRARY version' do
            LibMsPack.Version(LibMsPack::MSPACK_VER_LIBRARY).should eq(1)
        end

        it 'should return SYSTEM version' do
            LibMsPack.Version(LibMsPack::MSPACK_VER_SYSTEM).should eq(1)
        end

        it 'should return MSCHMD version' do
            LibMsPack.Version(LibMsPack::MSPACK_VER_MSCHMD).should eq(2)
        end
    end

end
